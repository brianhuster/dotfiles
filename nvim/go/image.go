package main

import (
	"image"
	_ "image/jpeg"
	_ "image/png"
	"log"
	"os"
	"github.com/neovim/go-client/nvim"
)

func getImageSize(imagePath string) (int, int, error) {
	file, err := os.Open(imagePath)
	if err != nil {
		return 0, 0, err
	}
	defer file.Close()

	img, _, err := image.DecodeConfig(file)
	if err != nil {
		return 0, 0, err
	}

	return img.Width, img.Height, nil
}

func sendImageSizeToNvim(v *nvim.Nvim, imagePath string) (map[string]int, error) {
	width, height, err := getImageSize(imagePath)
	if err != nil {
		v.WriteOut(err.Error())
		return nil, err
	}
	return map[string]int{"width": width, "height": height}, nil
}

func main() {
	log.SetFlags(0)
	stdout := os.Stdout
	os.Stdout = os.Stderr
	v, err := nvim.New(os.Stdin, stdout, stdout, log.Printf)
	if err != nil {
		log.Fatal(err)
	}
	v.RegisterHandler("get_image_size", sendImageSizeToNvim)
	if err := v.Serve(); err != nil {
		log.Fatal(err)
		v.WriteErr(err.Error())
	}
}
