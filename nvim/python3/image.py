from PIL import Image


def get_image_size(image_path):
    with Image.open(image_path) as img:
        width, height = img.size
    return width, height
