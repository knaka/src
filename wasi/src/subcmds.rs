// Code generated by build.rs; DO NOT EDIT.

mod subcmd_dm;
mod subcmd_hello;

fn register_subcommands(main_command: &mut App) {
    main_command.register_subcommand(subcmd_dm::meta(), Box::new(subcmd_dm::handler));
    main_command.register_subcommand(subcmd_hello::meta(), Box::new(subcmd_hello::handler));
}