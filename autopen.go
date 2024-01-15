package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"sync"
)

func main() {
	fmt.Println("AutoPen v.1")

	fmt.Print("Enter Domain: ")
	var url string
	fmt.Scanln(&url)

	// Create main directory
	if _, err := os.Stat(url); os.IsNotExist(err) {
		os.Mkdir(url, os.ModePerm)
	}

	// Create spinner function
	spinner := func(pid int) {
		delay := 100 * time.Millisecond
		spinstr := "|/-\\"
		for {
			if !processExists(pid) {
				break
			}
			temp := string(spinstr[1:]) + string(spinstr[0])
			fmt.Printf("\r [%c]  ", spinstr[0])
			spinstr = temp
			time.Sleep(delay)
		}
		fmt.Print("\r    \b\b\b\b\b")
	}

	// Create color functions
	red := func(text string) {
		fmt.Printf("\x1B[31m %s \x1B[0m\n", text)
	}
	blue := func(text string) {
		fmt.Printf("\x1B[34m %s \x1B[0m\n", text)
	}
	purple := func(text string) {
		fmt.Printf("\x1B[35m %s \x1B[0m", text)
	}

	red("Enter Domain in format: domain.com. Do not place www before.")
	fmt.Print("Enter Domain: ")
	fmt.Scanln(&url)

	// Function to create directory if not exists
	createDir := func(dir string) {
		if _, err := os.Stat(dir); os.IsNotExist(err) {
			os.Mkdir(dir, os.ModePerm)
		}
	}

	// Function to run command with arguments
	runCommand := func(command string, args ...string) {
		cmd := exec.Command(command, args...)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		cmd.Run()
	}

	// Function to check if a process with a given PID exists
	processExists := func(pid int) bool {
		process, err := os.FindProcess(pid)
		if err != nil {
			return false
		}
		err = process.Signal(os.Signal(syscall.Signal(0)))
		return err == nil
	}

	// Example usage of createDir and runCommand
	createDir(url)
	createDir(fmt.Sprintf("%s/recon", url))

	cmd := exec.Command("assetfinder", url)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Start()

	pid := cmd.Process.Pid
	spinnerWg := &sync.WaitGroup{}
	spinnerWg.Add(1)
	go func() {
		spinner(pid)
		spinnerWg.Done()
	}()

	cmd.Wait()
	spinnerWg.Wait()

}

	"sync"
	"syscall"
	"time"
)

// ...

func main() {
	// ...

	// Function to display the menu
	showMenu := func() {
		fmt.Println("========= MENU =========")
		fmt.Println("1. Recon")
		fmt.Println("2. Enumerate")
		fmt.Println("3. YOLO (BOTH)")
		fmt.Println("4. Exit")
		fmt.Println("========================")
	}

	// Function to print Directories and Files created to a table
	printRow := func(name, path string) {
		count := 0
		filepath.Walk(path, func(_ string, info os.FileInfo, _ error) error {
			if !info.IsDir() {
				count++
			}
			return nil
		})
		fmt.Printf("%-30s| %5d\n", name, count)
	}

	// Main program loop
	for {
		showMenu()
		fmt.Print("Enter your choice (1-4): ")
		var choice int
		fmt.Scanln(&choice)
		fmt.Println()

		switch choice {
		case 1:
			fmt.Println("Lets get to work...")
			runRecon(url)
		case 2:
			fmt.Println("Lets get to work...")
			runEnum(url)
		case 3:
			fmt.Println("Lets get to work...")
			runRecon(url)
			runEnum(url)
		case 4:
			fmt.Println("Exiting...")
			return
		default:
			fmt.Println("Invalid choice. Please enter a number from 1 to 4.")
		}
	}

	// ...
}

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

	// Continue with the rest of the enumerate function

	fmt.Println("Enumerate executed.")
}

// ...
