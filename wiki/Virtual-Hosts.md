
Name-based Virtual Host Support Source https://httpd.apache.org/docs/2.4/vhosts/name-based.html

```shell
$ sudo vim /etc/httpd/conf/httpd.conf
```

```apache
<VirtualHost *:80>
        ServerName bioghost.usc.edu
        # ServerAlias 
        DocumentRoot "/var/www/html/workshop"
</VirtualHost>

<VirtualHost *:80>
        ServerName image.usc.edu
        # ServerAlias 
        DocumentRoot "/var/www/html/image"
</VirtualHost>
```

```shell
httpd -k restart
```

1.  Copy the data into a writable folder
2.  Then put everything into `/var/www/html/image` for example