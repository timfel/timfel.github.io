# handle double loading
return if loadScript?

# load a external script, async if the browser supports it.
# runs callback after script is loaded.
loadScript = (file, callback, async) ->
  script        = document.createElement 'script'
  script.src    = file
  script.type   = 'text/javascript'
  script.async  = async ? true
  script.onload = callback if callback
  s             = document.getElementsByTagName('script')[0]
  s.parentNode.insertBefore(script, s)

# fancy auto hyphenation
loadScript 'http://hyphenator.googlecode.com/svn/tags/Version%203.0.0/Hyphenator.js', ->
  Hyphenator.config intermediatestate: 'visible'
  Hyphenator.run()

# nest everything in callback that depends on jquery
loadScript 'http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js', ->
  currentPage = false

  loadScript 'http://timeago.yarp.com/jquery.timeago.js', ->
    loadScript '/deferrable.js', ->
      lastEmbed = new Deferrable

      # load an external script that uses document.write for embedding
      # widgets. instead of writing content somewhere inline, a callback
      # is called an a string containing all strings handed to document.write
      # is passed to that callback.
      loadEmbedded  = (file, callback) ->
        deferred    = lastEmbed
        lastEmbed   = new Deferrable
        unlock      = lastEmbed.callback()
        deferred.onSuccess ->
          buffer            = ''
          writeWas          = document.write
          document.write    = (content) -> buffer = buffer.concat content
          wrappedCallback   = ->
            document.write  = writeWas
            callback buffer
            unlock()
          loadScript file, wrappedCallback, false

      # fancy ajax navigation
      if history.pushState?
        $(document).ready ->
          # page that is already loaded
          currentPage = $('article[data-source]')
          currentPath = -> currentPage[0].getAttribute('data-source')

          # global page wrapper
          wrapper = $('.blog')

          # loads a page via ajax if not already loaded
          # and triggeres a callback, avoiding double-load issues
          loadPage = (path) ->
            selector = "article[data-source='#{path}']"
            page = $("article[data-source='#{path}']")
            if page.lenght > 0
              page
            else
              $.get path, (data) ->
                page = $(data).find "article[data-source]"
                page.hide()
                wrapper.append page
                Hyphenator?.run()
                page

          # In what direction to move
          directionTo = (path) ->
            current = articles.indexOf currentPath()
            next    = articles.indexOf path
            return 0 if current == next or current == -1 or next == -1
            if current < next then 1 else -1

          # Switches from the current page to the page under path
          switchTo = (path) ->
            document.title = titles[path]
            $('.comments').html '&nbsp;'
            currentPage.css opacity: 0
            data = loadPage path
            currentPage.hide()
            currentPage = data.page[0]
            currentPage.show()
            preparePage()
            currentPagePage.css opacity: 1

          # track history events
          window.onpopstate = (event) ->
            path = currentPath()
            switchTo document.location.pathname if path and path != '' and document.location.pathname != path

          # hook into all links
          $('a[href^="/"]').on 'click', (event) ->
            path = this.getAttribute("href")
            history.pushState true, titles[path], path
            switchTo path
            event.preventDefault()

      preparePage = ->
        ## twitter buttons
        #loadScript 'http://platform.twitter.com/widgets.js'
        $('p > a[href^="http://gist.github.com/"]:only-child').each (index, element) ->
          loadEmbedded "#{element.href}.js?file=#{element.innerHTML}", (gist) ->
            wrapper = $(element).parent()
            wrapper.html gist
            wrapper.next().css 'text-indent': 0

        # disqus comments
        comments = if currentPage then currentPage.find('.comments') else $('.comments')
        window.disqus_identifier = document.location.pathname
        window.disqus_url = "#{document.location}"
        window.disqus_developer = 1 # Disqus doesn't seem to load on some of my articles without
        comments.html '<div id="disqus_thread"></div>'
        loadScript 'http://blogbithug.disqus.com/embed.js'

        # time ago for publishing date
        $("time.timeago").timeago()

      $(document).ready ->
        # evil disqus loading issue fix
        $('#dsq-loading-problem a:first-child').on 'click', (event) ->
          event.preventDefault()
          window.location.reload()
        preparePage()

# Google analytics
window._gaq ||= [];
window._gaq.push ['_setAccount', 'UA-25791824-1']
# window._gaq.push ['_setDomainName', '.bithug.org']
window._gaq.push ['_trackPageview']
loadScript 'http://www.google-analytics.com/ga.js'
