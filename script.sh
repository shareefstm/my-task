#!/bin/bash

              yum update -y
              yum install httpd -y

              systemctl start httpd
              systemctl enable httpd

              echo "<html>
              <head><title>Apache Server</title></head>
              <body style='background-color:black;'>
              <h1 style='color:lime;text-align:center;'>
              Apache Server Created Using Terraform
              </h1>
              </body>
              </html>" > /var/www/html/index.html