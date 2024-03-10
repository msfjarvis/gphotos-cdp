module.exports = {
  repositories: [
    "msfjarvis/gphotos-cdp",
  ],
  allowedPostUpgradeCommands: ["^sudo nix"],
  nix: { enabled: true, },
}
