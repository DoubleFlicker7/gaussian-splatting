docker run \
    -it \
    --name 3dgs_i2_2_c1_0 \
    --gpus all \
    -v /data/dataset/public:/data/dataset/public \
    -v /data/xuhaonan/project/gaussian-splatting/output:/workspace/gaussian-splatting/output \
    3dgs:v2.2 \
    bash