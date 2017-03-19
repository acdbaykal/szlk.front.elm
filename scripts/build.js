const handlebars = require('handlebars');
const fs = require('fs');
const path = require('path');
const cwd = process.cwd();
const source = fs.readFileSync(path.resolve(cwd, 'scripts/index.handlebars'), 'utf8');
const buildFile = './index.js';
const template = handlebars.compile(source);
const result = template({buildFile:buildFile});
fs.writeFileSync(path.resolve(cwd, 'build/index.html'), result);