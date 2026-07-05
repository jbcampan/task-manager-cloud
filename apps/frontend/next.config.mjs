/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,
    // Build "standalone": minimal Docker image without the full node_modules directory.
    // Used by the multi-stage Dockerfile and for ECS Fargate deployment.
    output: 'standalone'
};

export default nextConfig;
