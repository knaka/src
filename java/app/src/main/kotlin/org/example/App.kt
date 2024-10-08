/*
 * This source file was generated by the Gradle 'init' task
 */
package org.example

import picocli.CommandLine
import picocli.CommandLine.*
import kotlin.system.exitProcess

@Command(
    name = "app",
    mixinStandardHelpOptions = true,
    version = ["app 1.0"],
    description = ["Executes multiple subcommands."],
    subcommands = [
        HelpCommand::class,
        KotlinGreeting::class,
        SubcommandListing::class,
        JavaGreeting::class,
    ],
)
class App : Runnable {
    @Option(names = ["-n", "--name"], description = ["The name to greet"], defaultValue = "World")
    private var name: String? = null

    override fun run() {
        println("Hello, $name!")
        // Then show command help.
        CommandLine.usage(this, System.out)
    }

    @Command(
        name = "nop",
        description = ["Do nothing. Does not print anything."]
    )
    fun nop() {}

    val greeting: String
        get() {
            return "Greeting5"
        }
}

fun main(args: Array<String>) {
    val app = CommandLine(App())
    exitProcess(app.execute(*args))
}

@Command(
    name = "list",
    description = ["List all subcommands."],
        mixinStandardHelpOptions = true,
)

class SubcommandListing : Runnable {
    override fun run() {
        (CommandLine(App())).getSubcommands().forEach {
            println(it.key)
        }
    }
}
