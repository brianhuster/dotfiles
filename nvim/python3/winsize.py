import fcntl
import struct
import platform


def get_win_size():
    # Define the winsize structure format
    winsize_format = 'HHHH'

    # Determine the TIOCGWINSZ value based on the OS
    if platform.system().lower() == 'linux':
        TIOCGWINSZ = 0x5413
    elif platform.system().lower() in ['bsd', 'darwin']:
        TIOCGWINSZ = 0x40087468
    else:
        raise NotImplementedError('Unsupported OS')

    # Create a buffer for the winsize structure
    ws = struct.pack(winsize_format, 0, 0, 0, 0)

    # Perform the ioctl operation
    try:
        ws = fcntl.ioctl(0, TIOCGWINSZ, ws)
    except OSError as e:
        raise RuntimeError('Failed to get window size') from e

    # Unpack the winsize structure
    row, col, xpixel, ypixel = struct.unpack(winsize_format, ws)

    return row, col, xpixel, ypixel


print(get_win_size())
