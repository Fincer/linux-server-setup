### This file defines the structure of the real laboratory test which was performed as a part of the Linux server course in Haaga-Helia University of Applied Sciences in spring 2018.

0) Check existence of critical commands

1) Set up SSH & Apache

    - Test SSH
        - Harden SSH login policy
        - Customize SSH port (get ssh port from a separate variable)
        - Use public key authentication method
    
    - Test Apache
    - Remove Apache default site
    - Harden Apache security policy
    
    - Remove root login
    - Restrict root accessibility

    - Add a default user with sudo permissions
    - Enable userdir for this new user

2) Set up PHP, phpMyAdmin & MySQL

    - Set Apache PHP environment (get php version from a separate variable)
    - Set MySQL database
    - Configure phpMyAdmin

3) Set up firewall configuration with ufw

4) Set up a PHP website that takes user input and writes it into MySQL database in the web browser view

5) Set up and install Wordpress
    
    - Points to different DNS (/etc/hosts)
    - Create a symbolic link from /usr/share/wordpress to /var/www/html/wordpress

6) Check /var/log/auth.log for any suspicious SSH login attempts
    - multiple entries were present (you need to parse the log file to see all suspicious entries!)
