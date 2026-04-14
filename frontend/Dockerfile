# Use the official lightweight Nginx image
FROM nginx:alpine

# Copy the compiled Flutter web files to the Nginx serving directory
COPY build/web /usr/share/nginx/html

# Expose port 8080 (Cloud Run's default expected port)
EXPOSE 8080

# Cloud Run injects the $PORT environment variable. 
# We need to update Nginx to listen on this port instead of its default 80.
CMD ["sh", "-c", "sed -i 's/80/8080/g' /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]
