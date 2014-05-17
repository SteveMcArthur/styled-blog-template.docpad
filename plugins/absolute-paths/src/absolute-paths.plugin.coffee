# Export Plugin
module.exports = (BasePlugin) ->
    # Define Plugin
    class absolutePathPlugin extends BasePlugin
        # Plugin Name
        name: 'absolutepath'
        config:
            url: "/"
        util = require('util')
        renderAfter: (opts,next) ->
            docpad = @docpad
            if 'static' in docpad.getEnvironments()
                console.log 'Writing absolute urls'
                href = 'href="' + @config.url
                src = 'src="' + @config.url
                database = docpad.getCollection('html')
                #console.log(util.inspect(database.at(0)))
                database.forEach (document) ->
                    content = document.get('contentRendered')
                    console.log('checking: '+document.attributes.url)
                    if /href="\//.test(content)
                        if /\/posts\//.test(document.attributes.url)
                            content = content.replace(/href="\//g, 'href="../../')
                        else
                            content = content.replace(/href="\//g,'href="')
                    if /src="\//.test(content)
                        if /\/posts\//.test(document.attributes.url)
                            content = content.replace(/src="\//g, 'src="../../')
                        else
                            content = content.replace(/src="\//g, 'src="')
                    document.set('contentRendered',content)
                next()?
            else
                next()?

            # Chain
            @