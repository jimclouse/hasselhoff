express     = require "express"
path        = require "path"
bodyParser  = require "body-parser"
http        = require "http"
mssql       = require "../lib/mssql"
cors        = require "cors"

app = express()
app.set('root', process.cwd())

#get the port situated based on environment
_port = 9000;

app.use '/static', express.static(path.join(app.get('root'), 'static'))
# app.use cors(
#   origin: [
#     'http://localhost:9090'
#     'https://jobs.glgresearch.com/'
#   ]
#   credentials: true)
app.use(express.static(app.get("root") + '/public'))
app.use(bodyParser({ limit: '2mb' }))

app.use(  (req, res, next) ->
    res.setHeader('Access-Control-Allow-Origin', 'http://jobs.glgresearch.com')
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST')
    res.setHeader('Access-Control-Allow-Headers', 'X-Requested-With,content-type')
    res.setHeader('Access-Control-Allow-Credentials', true)
    next()
)

app.engine('html', require('ejs').renderFile)

app.locals =
  availableServers: process.env['CONNECTIONS']

#app.options '*', (req,res) -> res.send(200)

app.get '/', (req, res) -> res.render 'app.html'
app.get '/index', (req, res) -> res.render 'app.html'

app.get '/health', (req, res) -> res.send 200

app.post('/query', mssql.query)


app.get '*', (req, res) -> res.redirect '/#/404'

server = http.createServer(app)

server.listen _port, ->
    console.log "running on port #{_port}"
    console.log "App settings:", app.locals


module.exports = app
