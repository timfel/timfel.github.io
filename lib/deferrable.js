(function() {
  var Deferrable,
    __slice = [].slice;

  Deferrable = (function() {
    var callback, constructor, fire, onSuccess, succeeded;

    function Deferrable() {}

    constructor = function(options) {
      this.options = options || {
        autoFire: true
      };
      this.outstandingCallbacks = [];
      this.callbacks = [];
      this.counter = 1;
      this.results = {};
      return this.fired = false;
    };

    callback = function(name) {
      var _this = this;
      if (this.fired) {
        throw new Error('Deferrable has already been fired.');
      }
      name || (name = this.counter++);
      this.outstandingCallbacks.push(name);
      return function() {
        var index, result;
        result = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        index = _this.outstandingCallbacks.indexOf(name);
        if (index > -1) {
          _this.outstandingCallbacks.splice(index, 1);
        }
        _this.results[name] = result;
        return _this.onSuccess(false, {
          fire: false
        });
      };
    };

    succeeded = function() {
      return this.fired && this.outstandingCallbacks.length < 1;
    };

    fire = function() {
      return this.onSuccess(false, {
        fire: true
      });
    };

    onSuccess = function(callback, options) {
      options || (options = {
        fire: this.options.autoFire
      });
      if (callback) {
        this.callbacks.push(callback);
      }
      if (options.fire) {
        this.fired = true;
      }
      if (this.succeeded()) {
        while (!(this.callbacks.length < 1)) {
          this.callbacks.pop()(this.results);
        }
      }
      return this;
    };

    return Deferrable;

  })();

  Deferrable.Deferrable = Deferrable;

  if (typeof exports !== "undefined" && exports !== null) {
    exports.Deferrable = Deferrable;
  }

  if (typeof window !== "undefined" && window !== null) {
    window.Deferrable = Deferrable;
  }

  if (typeof module !== "undefined" && module !== null) {
    module.exports = Deferrable;
  }

}).call(this);
