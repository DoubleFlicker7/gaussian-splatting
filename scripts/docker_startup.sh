docker run \
    -it \
    --name 3dgs_i2_5_c1_1 \
    --gpus all \
    -v "$SSH_AUTH_SOCK":"$SSH_AUTH_SOCK" \
    -e SSH_AUTH_SOCK="$SSH_AUTH_SOCK" \
    -v /data/dataset/public:/data/dataset/public \
    -v /data/xuhaonan/project/gaussian-splatting/output:/workspace/gaussian-splatting/output \
    3dgs:2.5 \
    bash