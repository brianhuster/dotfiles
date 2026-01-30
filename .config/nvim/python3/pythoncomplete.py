import rlcompleter


def complete(text):
    completer = rlcompleter.Completer()
    completions = []
    i = 0
    while True:
        completion = completer.complete(text, i)
        if completion is None:
            break
        completions.append(completion)
        i += 1
    return completions
