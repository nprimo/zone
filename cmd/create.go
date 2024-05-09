/*
Copyright © 2024 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"embed"
	"fmt"
	"os"
	"path"
	"text/template"

	"github.com/spf13/cobra"
)

//go:embed templates/*
var tpl embed.FS

// createCmd represents the create command
var createCmd = &cobra.Command{
	Use:   "create",
	Short: "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {

		name, _ := cmd.Flags().GetString("name")
		if len(name) == 0 {
			fmt.Println("Name must be specified!")
			return
		}
		contType, _ := cmd.Flags().GetString("type")

		t := template.Must(template.ParseFS(tpl, "templates/*"))

		if err := os.Mkdir(name, os.ModePerm); err != nil {
			fmt.Printf("Error creating directory %q: %1\n", name, err)
			return
		}
		f, err := os.Create(path.Join(name, "README.md"))
		if err != nil {
			fmt.Printf("error creating %s/README.md: %s\n", name, err)
			return
		}

		if err = t.ExecuteTemplate(f, "subject", InputData{Name: name, Type: contType}); err != nil {
			fmt.Printf("error writing in %s/README.md: %s\n", name, err)
			return
		}
	},
}

type InputData struct {
	Name string
	Type string
}

func init() {
	rootCmd.AddCommand(createCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// createCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	createCmd.Flags().StringP("name", "n", "", "The name of the new content")
	createCmd.Flags().StringP("type", "t", "exercise", "The type of the new content [`exercise`|`project`]")
}
