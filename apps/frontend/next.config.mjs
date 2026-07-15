import path from 'node:path';

/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,
    // Build "standalone": minimal Docker image without the full node_modules directory.
    // Used by the multi-stage Dockerfile and for ECS Fargate deployment.
    output: 'standalone',
    experimental: {
        // Required in an npm workspaces monorepo: without this, the standalone
        // build traces dependencies only from apps/frontend, missing packages
        // hoisted to the repo-root node_modules by npm workspaces.
        // Note: still under `experimental` in Next.js 14 — stabilized (moved to
        // top-level) only in Next.js 15.
        outputFileTracingRoot: path.join(process.cwd(), '../../'),
    },
};

export default nextConfig;
