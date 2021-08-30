FROM lambci/lambda:build-python3.8

COPY create_and_push_layer.sh .

# Change permissions on the startup script
RUN yum install openssl dos2unix -y \
    && chmod +x create_and_push_layer.sh \
    && dos2unix create_and_push_layer.sh \
    && mkdir -p ~/output

ENTRYPOINT ["./create_and_push_layer.sh"]