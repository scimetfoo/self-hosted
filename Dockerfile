FROM actualbudget/actual-server:24.8.0

# Install NGINX
RUN apt-get update && apt-get install -y nginx

# Remove default NGINX config (optional if you want custom NGINX)
RUN rm /etc/nginx/sites-enabled/default

# Copy your custom NGINX configuration into the container
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port for NGINX
EXPOSE 80
EXPOSE 443

# Start NGINX and Actual server
CMD service nginx start && actual-server

