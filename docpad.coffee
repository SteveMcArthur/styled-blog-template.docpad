# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
docpadConfig = {

    #port:5858
    # =================================
    # Template Data
    # These are variables that will be accessible via our templates
    # To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

    templateData:

        # Specify some site properties
        site:
            # The production url of our website
            # If not set, will default to the calculated site URL (e.g. http://localhost:9778)
            url: "http://docpad.org"

            # Here are some old site urls that you would like to redirect from
            oldUrls: [
                'www.docpad.org',
                'website.herokuapp.com'
            ]

            # The default title of our website
            title: "Simple Blog"

            # The website description (for SEO)
            description: """
                When your website appears in search results in say Google, the text here will be shown underneath your website's title.
                """

            # The website keywords (for SEO) separated by commas
            keywords: """
                place, your, website, keywoards, here, keep, them, related, to, the, content, of, your, website
                """

            # The website's styles
            styles: [
                '/css/foundation.css'
                '/css/header.css'
                '/css/icon-fonts.css'
                '/css/hover.css'
                '/css/footer-bottom.css'
                '/css/basic-icon.css'
                '/css/icon.css'
                '/css/button.css'
                '/css/segment.css'
                '/css/menu.css'
                '/css/blog.css'
                '/css/fonts.css'
                '/css/color.css'
            ]

            # The website's scripts
            scripts: [
                '/js/jquery.js'
                '/js/foundation.min.js'
                """
                <script>$(document).foundation();</script>
                """
            ]


        # -----------------------------
        # Helper Functions

        # Get the prepared site/document title
        # Often we would like to specify particular formatting to our page's title
        # we can apply that formatting here
        getPreparedTitle: ->
            # if we have a document title, then we should use that and suffix the site's title onto it
            if @document.title
                "#{@document.title} | #{@site.title}"
            # if our document does not have it's own title, then we should just use the site's title
            else
                @site.title

        # Get the prepared site/document description
        getPreparedDescription: ->
            # if we have a document description, then we should use that, otherwise use the site's description
            @document.description or @site.description

        # Get the prepared site/document keywords
        getPreparedKeywords: ->
            # Merge the document keywords with the site keywords
            @site.keywords.concat(@document.keywords or []).join(', ')
            
        # Get a list of all categories from all posts
        getCategories: ->
            cat = []
            # iterate thru documents
            @getCollection('posts').forEach (document) ->
                docat = document.getMeta().get('category')
                if !(docat in cat)
                    cat.push(docat)
            return cat
        
         # Get a list of all categories from all posts
        getTags: ->
            cat = []
            # iterate thru documents
            @getCollection('posts').forEach (document) ->
                docat = document.getMeta().get('category')
                if !(docat in cat)
                    cat.push(docat)
            return cat
        
        # Get the current year
        thisYear: (new Date()).getFullYear()
        
        # Used for shortening a post
        truncateText: (content,trimTo) ->
            trimTo = trimTo || 200
            output = content.substr(0,trimTo).trim()
            #remove anchor tags as they don't show up on the page
            nolinks = output.replace(/<a(\s[^>]*)?>.*?<\/a>/ig,"")
            #check if there is a difference in length - if so add this
            #difference to the trimTo length (add the text length that will not show
            #up in the rendered HTML
            diff = output.length - nolinks.length
            output = content.substr(0,trimTo + diff)
            #find the last space so that don't break the text
            #in the middle of a word
            i = output.lastIndexOf(' ',output.length-1)
            output.substr(0,i)+"..."
            
        getRecentPosts: ->
            posts = @getCollection('documents').findAllLive({relativeOutDirPath: 'posts'},[{date:-1}])
            return [posts.at(2).toJSON(),posts.at(3).toJSON()]
        
        getComments: (slug) ->
            @getCollection('comments').findAll({'postslug': slug},[{date:-1}])
            
        getByCateogory: (category) ->
            @getCollection('posts').findAll({'category':category},[{date:-1}])
            
            


    # =================================
    # Collections

    # Here we define our custom collections
    # What we do is we use findAllLive to find a subset of documents from the parent collection
    # creating a live collection out of it
    # A live collection is a collection that constantly stays up to date
    # You can learn more about live collections and querying via
    # http://bevry.me/queryengine/guide

    collections:

        # Create a collection called posts
        # That contains all the documents that will be going to the out path posts
        posts: ->
            @getCollection('documents').findAllLive({relativeOutDirPath: 'posts'},[{date:-1}])
        popularPosts: ->
            @getCollection('documents').findAllLive({relativeOutDirPath: 'posts',popular:$exists:true},[{date:-1}])
        #comments: ->
            #@getCollection('documents').findAllLive({relativeOutDirPath: 'comments'},[{date:-1}])
        pdfs: ->
            @getCollection('files').findAllLive({relativeOutDirPath: 'pdfs'},[{date:-1}])
        
        


    # =================================
    # Environments

    # DocPad's default environment is the production environment
    # The development environment, actually extends from the production environment

    # The following overrides our production url in our development environment with false
    # This allows DocPad's to use it's own calculated site URL instead, due to the falsey value
    # This allows <%- @site.url %> in our template data to work correctly, regardless what environment we are in
    env: 'production'

    environments:
        development:
            templateData:
                site:
                    url: false


    # =================================
    # DocPad Events

    # Here we can define handlers for events that DocPad fires
    # You can find a full listing of events on the DocPad Wiki

    events:

        # Server Extend
        # Used to add our own custom routes to the server before the docpad routes are added
        serverExtend: (opts) ->
            # Extract the server from the options
            {server} = opts
            docpad = @docpad
            database = docpad.getDatabase()
            path = require('path')
            safefs = require('safefs')
            util = require('util')

            # As we are now running in an event,
            # ensure we are using the latest copy of the docpad configuraiton
            # and fetch our urls from it
            latestConfig = docpad.getConfig()
            oldUrls = latestConfig.templateData.site.oldUrls or []
            newUrl = latestConfig.templateData.site.url

            # Redirect any requests accessing one of our sites oldUrls to the new site url
            server.use (req,res,next) ->
                if req.headers.host in oldUrls
                    res.redirect(newUrl+req.url, 301)
                else
                    next()
                    
            server.get /\/admin\/[a-zA-z0-9\-]+(\/)?(\.html)?$/, (req,res,next) ->
                console.log(req.url)
                items = req.url.split("\/")
                slug = items[items.length-1].toLowerCase().replace(".html","")
                console.log(slug)
                document = docpad.getCollection('documents').findOne({relativeOutPath: path.join('admin','post','index.html')})
                #document = docpad.getCollection('documents').findOne({relativeOutPath: path.join('admin','post','index.html')}).toJSON()
                #require('fs').writeFileSync('document.json',require('util').inspect(documents))
                document.attributes.postSlug = slug
                docpad.serveDocument({
                    document: document,
                    req: req,
                    res: res,
                    next: next,
                    statusCode: 200
                })
            #don't call next as the request stops here because we are serving the document
            
            server.post /\/admin\/save\/[a-zA-z0-9\-]+/, (req,res,next) ->
                console.log(req.body)
                
                if (req.body.content && req.body.id)
                    document = docpad.getCollection('documents').findOne({slug:req.body.id}).toJSON()
                    outFile = document.fullPath
                    documentAttributes =
                        content: req.body.content or document.content
                        meta: document.meta
              
                        
                    # Write source which will trigger the regeneration
                    # but we don't have to wait for the page to be regenerated
                    # as the page will be updated by ajax
                    meta = ""
                    for key, val of documentAttributes.meta
                        meta+= key+": "+val+"\r\n"
                    content = '---\r\n'+meta+'\r\n---\r\n'+documentAttributes.content
                    safefs.writeFile outFile, content
                    return res.json({success:true})
                else
                    return res.json({success:false})

}

# Export our DocPad Configuration
module.exports = docpadConfig