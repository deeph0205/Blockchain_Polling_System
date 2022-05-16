App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',
  hasVoted: false,

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    // TODO: refactor conditional
    if (typeof web3 !== 'undefined') {
      // If a web3 instance is already provided by Meta Mask.
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      // Specify default instance if no web3 instance provided
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("Polling_System.json", function(Polling_System) {
      // Instantiate a new truffle contract from the artifact
      App.contracts.Polling_System = TruffleContract(Polling_System);
      // Connect provider to interact with contract
      App.contracts.Polling_System.setProvider(App.web3Provider);

      App.listenForEvents();

      return App.render();
    });
  },

  // Listen for events emitted from the contract
  listenForEvents: function() {
    App.contracts.Polling_System.deployed().then(function(instance) {
      // Restart Chrome if you are unable to receive this event
      // This is a known issue with Metamask
      // https://github.com/MetaMask/metamask-extension/issues/2393
      instance.votedEvent({}, {
        fromBlock: 0,
        toBlock: 'latest'
      }).watch(function(error, event) {
        console.log("event triggered", event)
        // Reload when a new vote is recorded
        App.render();
      });
    });
  },

  render: function() {
    var pollingInstance;
    var loader = $("#loader");
    var content = $("#content");

    loader.show();
    content.hide();

    // Load account data
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });

    // Load contract data
    App.contracts.Polling_System.deployed().then(function(instance) {
      pollingInstance = instance;
      return pollingInstance.number_of_polls();
    }).then(function(number_of_polls) {
      var pollsResults = $("#pollsResults");
      pollsResults.empty();

      var pollsSelect = $('#pollsSelect');
      pollsSelect.empty();

      for (var i = 1; i <= number_of_polls; i++) {
        electionInstance.List_of_Polls(i).then(function(poll) {
          var question = poll[3];
          var choice1 = poll[4];
          var choice2 = poll[6];
          var choice3 = poll[8];

          // Render candidate Result
          var pollTemplate = "<tr><th>" + question + "</th><td>" + choice1 + "</td><td>" + choice2 + "</td></tr>" + choice3 + "</td></tr>"
          pollsResults.append(pollTemplate);

          // Render candidate ballot option
          var pollOption = "<option value='" + i + "' >" + question + "</ option>"
          pollsSelect.append(pollOption);

          var choiceOption = "<option value='" + 1 + "' >" + choice1 + "</ option>"
          choiceSelect.append(choiceOption);

          var choiceOption = "<option value='" + 2 + "' >" + choice2 + "</ option>"
          choiceSelect.append(choiceOption);

          var choiceOption = "<option value='" + 3 + "' >" + choice3 + "</ option>"
          choiceSelect.append(choiceOption);

        });
      }
      return pollingInstance.Users(App.account);
    }).then(function(hasVoted) {
      // Do not allow a user to vote
      if(hasVoted) {
        $('form').hide();
      }
      loader.hide();
      content.show();
    }).catch(function(error) {
      console.warn(error);
    });
  },
  
  castVote: function() {
    var pollId = $('#pollsSelect').val();
    var choiceId = $('#pollsSelect').val();
    App.contracts.Polling_System.deployed().then(function(instance) {
      return instance.vote(pollId, { from: App.account });
    }).then(function(result) {
      // Wait for votes to update
      $("#content").hide();
      $("#loader").show();
    }).catch(function(err) {
      console.error(err);
    });
  },
  


  createPoll: function() {
    var i_question = $('#question').val();
    var i_settime = $('#settime').val();
    var i_choice1 = $('#choice1').val();
    var i_choice2 = $('#choice2').val();
    var i_choice3= $('#choice3').val();

    App.contracts.Polling_System.deployed().then(function(instance) {
      return instance.createPoll(i_settime,i_question,i_choice1,i_choice2,i_choice3,{ from: App.account });
    });
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});