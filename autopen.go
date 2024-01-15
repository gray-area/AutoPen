package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"syscall"
	"time"
)

// ...

// Function to run Recon
func runRecon(url string) {
	fmt.Println("Running Recon...")

	// Recon Dir Creation
	createDir(fmt.Sprintf("%s/recon", url))
	createDir(fmt.Sprintf("%s/recon/gowitness", url))
	// Add more directory creations as needed

	// ...

	// Example usage of running commands
	runCommand("assetfinder", url, fmt.Sprintf("&> %s/recon/final.txt", url))

	// Continue with the rest of the recon function

	fmt.Println("Recon executed.")
}

// Function to run Enumerate
func runEnum(url string) {
	fmt.Println("Running Enumerate...")

	// Enumerate Dir Creation
	createDir(fmt.Sprintf("%s/enumeration", url))
	createDir(fmt.Sprintf("%s/enumeration/whatweb", url))
	// Add more directory creations as needed

	// ...

	// Example usage of running commands
	runCommand("whatweb", fmt.Sprintf("www.%s", url), fmt.Sprintf("&> %s/enumeration/whatweb/whatweb.txt", url))
	// Continue with the rest of the enumerate function

	fmt.Println("Enumerate executed.")
}

// Function to browse gowitness images and launch server
func browseGowitness(url string) {
	fmt.Print("Would you like to browse gowitness images and launch server? (yes or no) ")
	var yesorno string
	fmt.Scanln(&yesorno)

	if strings.ToLower(yesorno) == "yes" {
		// TODO: Add code to open a browser or launch gowitness server
	} else if strings.ToLower(yesorno) == "no" {
		os.Exit(1)
	} else {
		red("Not a valid answer.")
		os.Exit(1)
	}
}

// Main program loop
func main() {
	// ...

	// Example usage of printRow
	fmt.Println()
	blue("[+] Here are the locations and number of files created...Happy Hacking!")
	fmt.Println()
	seperator := strings.Repeat("-", 30)
	fmt.Printf("%-30s| %s\n", "Directory", "Files")
	fmt.Printf("%-30s|%s\n", seperator, seperator)

	printRow("/recon/scans", fmt.Sprintf("%s/recon/scans", url))
	printRow("/recon/httprobe", fmt.Sprintf("%s/recon/httprobe", url))
	// Add more printRow calls as needed

	// ...

	// Example usage of browseGowitness
	browseGowitness(url)
}

// ...
