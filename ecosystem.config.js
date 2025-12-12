module.exports = {
    apps: [{
      name: 'ec2-poc-api',
      script: 'src/server.js',
      instances: 1, // or 'max' for cluster mode
      exec_mode: 'fork', // or 'cluster' for load balancing
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: './logs/err.log',
      out_file: './logs/ou