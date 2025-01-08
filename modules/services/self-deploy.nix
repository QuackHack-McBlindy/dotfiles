{
    services.self-deploy = { 
        enable = true;
        startAt = "hourly";
        switchCommand = "switch";

        # The repository to fetch from. Must be properly formatted for git.
        # If this value is set to a path (must begin with /) then it’s assumed that the repository is local and the resulting service won’t wait for the network to be up.
        # If the repository will be fetched over SSH, you must add an entry to programs.ssh.knownHosts for the SSH host for the fetch to be successful.
        repository = 
      
        # Path to nix file in repository. Leading ‘/’ refers to root of git repository.
        nixFile = "/default.nix";
      
        # Attribute of nixFile that builds the current system.
        # nixAttribute = null;
      
        # Arguments to nix-build passed as --argstr or --arg depending on the type.
        nixArgs = {};
      
        # Branch to track. Technically speaking any ref can be specified here, as this is passed directly to a git fetch, but for the use-case of continuous deployment you’re likely to want to specify a branch.
        branch = "master";

        # Path to SSH private key used to fetch private repositories over SSH.
        # sshKeyFile = { };
    };
}  



