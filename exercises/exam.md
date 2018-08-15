0) Check critical commands

1) Set up SSH & Apache

    - Test SSH
        - Harden SSH login policy
        - Customize SSH port (get ssh port from a separate variable)
        - Use public key authentication method
    
    - Test Apache
    - Remove Apache default site
    - Strict Apache security policy
        - Apply custom patch to the source code
    
    - Remove root login
    - Restrict root accessibility

    - Add a default user with sudo permissions
    - Enable userdir for this new user

2) Set up PHP, phpMyAdmin & MySQL

    - Set Apache PHP environment (get php version from a separate variable)
    - Set MySQL database
    - Configure phpMyAdmin

3) Set up firewall configuration with ufw

4) Set up a PHP website that takes user input and writes it into MySQL database

5) Set up and install Wordpress
    
    - Points to different DNS (/etc/hosts)

6) Check /var/log/auth.log for any suspicious SSH login attempts
