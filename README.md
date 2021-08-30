Reusable terraform modules.

# Build layer
`docker build . -f layer.Dockerfile -t layer-module`
`docker run -v ~\modules\datapump:/var/task/output layer-module`