FROM nginx:alpine

# Install the image filter module package
RUN apk add --no-cache nginx-module-image-filter

# Inject the load_module directive at the absolute top of the root nginx.conf
RUN sed -i '1s/^/load_module modules\/ngx_http_image_filter_module.so;\n/' /etc/nginx/nginx.conf