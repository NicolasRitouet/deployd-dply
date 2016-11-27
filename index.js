const deployd = require('deployd'),
    os = require('os');

const server = deployd({
    port: process.env.PORT || 3000,
    env: 'development',
    db: {
        host: 'localhost',
        port: 27017,
        name: 'dply'
    }
});

server.listen();
console.log('Express server listening on http://' + os.hostname() + ":" + server.options.port + " with DB " + server.options.db.host + "/" + server.options.db.name);

server.on('error', (err) => {
    console.error(err);
    process.nextTick(() => {
        process.exit();
    });
});