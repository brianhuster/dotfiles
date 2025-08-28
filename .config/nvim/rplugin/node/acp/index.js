import { spawn } from "node:child_process";
import { WritableStream, ReadableStream } from "node:stream/web";
import { Writable, Readable } from "node:stream";
import * as acp from "@zed-industries/agent-client-protocol";

/** @implements {acp.Client} */
class AcpClient {
	/** @param {import('neovim').Neovim} nvim */
	constructor (nvim) {
		this.nvim = nvim
	}

	/**
		* @param {acp.RequestPermissionRequest} params
		* @returns {Promise<acp.RequestPermissionResponse>}
		*/
	async requestPermission(params) {
		console.log(`\n🔐 Permission requested: ${params.toolCall.title}`);

		const inputlist = [`🔐 Permission requested: ${params.toolCall.title}`]

		params.options.forEach((option, index) => {
			inputlist.push(`   ${index + 1}. ${option.name} (${option.kind})`);
		})

		/** @type {number} */
		const answer = await this.nvim.call('inputlist', [inputlist])
		const optionIndex = answer - 1;

		if (optionIndex >= 0 && optionIndex < params.options) {
			return {
				outcome: {
					outcome: "selected",
					optionId: params.options[optionIndex].optionId,
				},
			};
		} else {
			console.log("Invalid option. Defaulting to cancel.");
			return {
				outcome: {
					outcome: "cancelled",
				},
			};
		}
	}

	/**
		* @param {acp.SessionNotification} params
		* @returns { Promise<void> }
		*/
	async sessionUpdate(params) {
		const update = params.update;
		const buffer = await this.nvim.buffer

		switch (update.sessionUpdate) {
			case "agent_message_chunk":
				if (update.content.type === "text") {
					this.nvim.call("append", [update.content.text])
					buffer.setLines(update.content.type, { start: -2, end: -2 })
				} else {
					buffer.setLines(update.content.type, { start: -2, end: -2 })
				}
				break;
			case "tool_call":
				buffer.setLines(`\n🔧 ${update.title} (${update.status})`, { start: -2, end: -2 })
				break;
			case "tool_call_update":
				buffer.setLines(
					`\n🔧 Tool call \`${update.toolCallId}\` updated: ${update.status}\n`,
					{ start: -2, end: -2 }
				);
				break;
			case "plan":
			case "agent_thought_chunk":
			case "user_message_chunk":
				buffer.setLines(`[${update.sessionUpdate}]`, { start: -2, end: -2 })
				break;
		}
	}

	/**
		* @param { acp.WriteTextFileRequest } params
		* @returns { Promise<acp.WriteTextFileResponse>}
		*/
	async writeTextFile(params) {
		console.error(
			"[Client] Write text file called with:",
			JSON.stringify(params, null, 2),
		);

		return null;
	}

	/**
		* @param { acp.ReadTextFileRequest } params
		* @returns { Promise<acp.ReadTextFileResponse>}
		*/
	async readTextFile(params) {
		console.error(
			"[Client] Read text file called with:",
			JSON.stringify(params, null, 2),
		);

		return {
			content: "Mock file content",
		};
	}
}

/**
	* @param {import('neovim').NvimPlugin} plugin
	*/
function AcpPlugin (plugin) {
	this.plugin = plugin

	const agentProcess = spawn("gemini", ["--experimental-acp"], {
		stdio: ["pipe", "pipe", "inherit"],

	});

	process.on('exit', () => {
		agentProcess.kill();
	});

	/** @type {WritableStream} */
	const input = Writable.toWeb(agentProcess.stdin)
	/** @type {ReadableStream<Uint8Array>} */
	const output = Readable.toWeb(agentProcess.stdout)
	const client = new AcpClient(plugin.nvim);
	const connection = new acp.ClientSideConnection(
		(_agent) => client,
		input,
		output,
	);

	connection.initialize({
		protocolVersion: acp.PROTOCOL_VERSION,
		clientCapabilities: {
			fs: {
				readTextFile: true,
				writeTextFile: true,
			},
		},
	});

	this.connection = connection
	plugin.registerFunction('AcpNewSession', [this, AcpPlugin.prototype.newSession], { sync: true });
	plugin.registerFunction('AcpPrompt', (args) => {
		const prompt = args[0]
		connection.prompt(prompt)
	}, { sync: false });
}

AcpPlugin.prototype.newSession = async function() {
	const session = await this.connection.newSession({
		cwd: process.cwd(),
		mcpServers: [],
	});
	return session.sessionId;
}

export default AcpPlugin
