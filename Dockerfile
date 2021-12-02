FROM node:alpine

RUN  apk --no-cache add g++ make curl-dev bash python3 && npm install -g insomnia-inso

# You should set an Environment Variable on the Host OS building this image to "SPEC_PATH".
# Pass the variable in through the cli when running "docker build" with the flag "--build-arg $SPEC_PATH"
ARG SPEC_PATH
ENV INSO_SPEC_PATH=$SPEC_PATH

# You can use this below "ADD" function to obtain files from online to the VM filesystem.
# ADD http://example.com/api-openapi-spec.yaml /usr/local/inso-cli/

# You can copy files from the host filesystem to the VM filesystem with the below "COPY" function.
COPY ./ /usr/local/inso-cli/

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["inso lint spec $INSO_SPEC_PATH"]