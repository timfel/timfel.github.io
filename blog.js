(function() {
  var loadScript;

  if (typeof loadScript !== "undefined" && loadScript !== null) {
    return;
  }

  loadScript = function(file, callback, async) {
    var s, script;
    script = document.createElement('script');
    script.src = file;
    script.type = 'text/javascript';
    script.async = async != null ? async : true;
    if (callback) {
      script.onload = callback;
    }
    s = document.getElementsByTagName('script')[0];
    return s.parentNode.insertBefore(script, s);
  };

  loadScript('/lib/Hyphenator.js', function() {
    Hyphenator.config({
      intermediatestate: 'visible'
    });
    return Hyphenator.run();
  });

  loadScript('/lib/jquery.min.js', function() {
    var currentPage;
    currentPage = false;
    return loadScript('/lib/jquery.timeago.js', function() {
      return loadScript('/lib/deferrable.js', function() {
        var lastEmbed, loadEmbedded, preparePage;
        lastEmbed = new Deferrable;
        loadEmbedded = function(file, callback) {
          var deferred, unlock;
          deferred = lastEmbed;
          lastEmbed = new Deferrable;
          unlock = lastEmbed.callback();
          return deferred.onSuccess(function() {
            var buffer, wrappedCallback, writeWas;
            buffer = '';
            writeWas = document.write;
            document.write = function(content) {
              return buffer = buffer.concat(content);
            };
            wrappedCallback = function() {
              document.write = writeWas;
              callback(buffer);
              return unlock();
            };
            return loadScript(file, wrappedCallback, false);
          });
        };
        if (history.pushState != null) {
          $(document).ready(function() {
            var currentPath, wrapper;
            currentPage = $('article[data-source]');
            currentPath = function() {
              return currentPage[0].getAttribute('data-source');
            };
            return wrapper = $('.blog');
          });
        }
        preparePage = function() {
          $('p > a[href^="//gist.github.com/"]:only-child').each(function(index, element) {
            return loadEmbedded(element.href + ".js?file=" + element.innerHTML, function(gist) {
              var wrapper;
              wrapper = $(element).parent();
              wrapper.html(gist);
              return wrapper.next().css({
                'text-indent': 0
              });
            });
          });
          $('p > a[href^="//www.youtube.com/embed/"]:only-child').each(function(index, element) {
            var wrapper;
            wrapper = $(element).parent();
            return wrapper.html("<iframe src=\"" + element.href + "\" class=\"ytVideo\" frameborder=\"0\" allowfullscreen=\"1\" />");
          });
          return $("time.timeago").timeago();
        };
        return $(document).ready(function() {
          $("aside").bind('touchstart', function(event) {
            return $(this).toggleClass('hover_effect');
          });
          $('#dsq-loading-problem a:first-child').on('click', function(event) {
            event.preventDefault();
            return window.location.reload();
          });
          return preparePage();
        });
      });
    });
  });

}).call(this);
