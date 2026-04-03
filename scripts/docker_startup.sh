docker run \
    -it \
    --name 3dgs_i2_7_c1_0 \
    --gpus all \
    -v "$SSH_AUTH_SOCK":"$SSH_AUTH_SOCK" \
    -e SSH_AUTH_SOCK="$SSH_AUTH_SOCK" \
    -v /data/dataset/public:/data/dataset/public \
    -v /data/xuhaonan/project/gaussian-splatting/output:/workspace/gaussian-splatting/output \
    3dgs:v2.7 \
    bash