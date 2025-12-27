FROM nginx:alpine

# Copy static files to nginx html directory
COPY index.html /usr/share/nginx/html/
COPY styles.css /usr/share/nginx/html/
COPY assets/ /usr/share/nginx/html/assets/

# Fix permissions (files 644, directories 755)
RUN chmod 644 /usr/share/nginx/html/*.html /usr/share/nginx/html/*.css && \
    chmod 755 /usr/share/nginx/html/assets && \
    chmod 644 /usr/share/nginx/html/assets/*

# Custom nginx configuration for better caching and security
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    \
    location ~* \.(png|jpg|jpeg|gif|ico|svg|woff|woff2)$ { \
        expires 30d; \
        add_header Cache-Control "public, immutable"; \
    } \
    \
    location ~* \.(css|js)$ { \
        expires 7d; \
        add_header Cache-Control "public"; \
    } \
    \
    add_header X-Frame-Options "SAMEORIGIN" always; \
    add_header X-Content-Type-Options "nosniff" always; \
    add_header X-XSS-Protection "1; mode=block" always; \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
