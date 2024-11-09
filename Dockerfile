FROM centos:7

# Install git and Apache
RUN yum install -y git httpd

# Copy the entire AICTE folder into /var/www/html/
COPY AICTE /var/www/html/

# Expose port 80
EXPOSE 80

# Set the working directory
WORKDIR /var/www/html/

# Start the Apache server
CMD ["httpd", "-D", "FOREGROUND"]
