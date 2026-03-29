docker run \
    -it \
    --gpus all \
    -v /data/dataset/public:/data/dataset/public:ro \
    -v /data/xuhaonan/project/gaussian-splatting/output:/workspace/gaussian-splatting/output \
    3dgs:v2.2 \
    bash