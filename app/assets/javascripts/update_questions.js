$(document).on('turbolinks:load', function() {
  (function() {
    App.question = App.cable.subscriptions.create({
      channel: 'UpdateQuestionsChannel'
    },
    {
      connected: function() {},
      disconnected: function() {},
      received: function(data) {
        $('#question-content-'+ data.id).html(data.question);
        $('#question-history').load(window.location + " #question-history");
        $('#question-data').load(window.location + " #question-data");
      },
    });
  }).call(this);
})
