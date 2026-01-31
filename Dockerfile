# 构建阶段
FROM rustlang/rust:nightly-alpine as builder
RUN apk add --no-cache musl-dev binaryen
RUN cargo install --locked trunk
RUN rustup target add wasm32-unknown-unknown

WORKDIR /app
COPY . .
# 编译生成静态文件，默认输出到 /app/dist
RUN trunk build --release

# 运行阶段 (使用 Nginx 托管)
FROM nginx:alpine
# 将构建好的 dist 目录拷贝到 nginx 静态资源目录
COPY --from=builder /app/dist /usr/share/nginx/html
# 如果有 SPA 路由需求，需要覆盖默认配置以支持 index.html 内部跳转
# COPY nginx.conf /etc/nginx/conf.d/default.conf 
EXPOSE 80