/*
Copyright © 2024 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"fmt"
	"os"
	"os/exec"

	"github.com/spf13/cobra"
)

// testCmd represents the test command
var testCmd = &cobra.Command{
	Use:   "test",
	Short: "Test an exercise using zone CLI.",
	Long:  `Test an exercise using the zone CLI.`,
	Run: func(cmd *cobra.Command, args []string) {
		lang, _ := cmd.Flags().GetString("lang")

		if lang == "" || len(args) != 1 {
			fmt.Println("Print help message")
			return
		}
		name := args[0]

		testWithContainerCmd := exec.Cmd{
			Path:   "./scripts/test_with_container.sh",
			Args:   []string{"", name, lang},
			Stdout: os.Stdout,
			Stderr: os.Stderr,
		}

		if err := testWithContainerCmd.Start(); err != nil {
			fmt.Printf("Got an error??? %v\n", err)
			os.Exit(1)
		}
		if err := testWithContainerCmd.Wait(); err != nil {
			fmt.Printf("%v\n", err)
			os.Exit(1)
		}
	},
}

func init() {
	rootCmd.AddCommand(testCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	testCmd.PersistentFlags().String("lang", "java", "The language of the content to test")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// testCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
