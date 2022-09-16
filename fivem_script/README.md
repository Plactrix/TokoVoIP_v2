
# Installation
Step 1: Download the latest version of tokovoip-script.zip from the releases section
Step 2: Upload it to your server's resources folder
Step 3: Configure all options in config.lua to fit your servers needs (Note: When configuring channel names, if it contains "Call", it will be displayed as a phone call on the voice overlay)
Step 4: Install ws_server
Step 5: Install TeamSpeak3 Plugin

## API Reference

## Client exports
- ### addPlayerToRadio(channel)

  Adds the player to a radio channel

  <table>
  <tr>
    <th>Params</th>
    <th>type</th>
    <th>Details</th>
  </tr>
  <tr>
    <td>channel</td>
    <td>number</td>
    <td>Id of the radio channel</td>
  </tr>
    <tr>
    <td>isRadio</td>
    <td>boolean</td>
    <td>If set to true, channel will be handled as a radio, false will handle the channel as a phone call</td>
  </tr>
  </table>

- ### removePlayerFromRadio(channel)

  Removes the player from a radio channel

  <table>
  <tr>
    <th>Params</th>
    <th>type</th>
    <th>Details</th>
  </tr>
  <tr>
    <td>channel</td>
    <td>number</td>
    <td>Id of the radio channel</td>
  </tr>
  </table>

- ### isPlayerInChannel(channel)

  Returns true if the player is in the specified radio channel

  <table>
  <tr>
    <th>Params</th>
    <th>type</th>
    <th>Details</th>
  </tr>
  <tr>
    <td>channel</td>
    <td>number</td>
    <td>Id of the radio channel</td>
  </tr>
  </table>

- ### clientRequestUpdateChannels()

  Requests to update the local radio channels
  </table>

- ### setPlayerData(playerName, key, data, shared)

  Sets a data key on the specified player
  Note: if the data is not shared, it will only be available to the local player

  <table>
  <tr>
    <th>Params</th>
    <th>type</th>
    <th>Details</th>
  </tr>
  <tr>
    <td>playerName</td>
    <td>string</td>
    <td>Name of the player to apply the data to</td>
  </tr>
  <tr>
    <td>key</td>
    <td>string</td>
    <td>Name of the data key</td>
  </tr>
  <tr>
    <td>data</td>
    <td>any</td>
    <td>Data to save in the key</td>
  </tr>
  <tr>
    <td>shared</td>
    <td>boolean</td>
    <td>If set to true, will sync through network to all the players</td>
  </tr>
  </table>

- ### getPlayerData(playerName, key)

  Returns the data of matching player and key

  <table>
  <tr>
    <th>Params</th>
    <th>type</th>
    <th>Details</th>
  </tr>
  <tr>
    <td>playerName</td>
    <td>string</td>
    <td>Name of the player to retrieve the data from</td>
  </tr>
  <tr>
    <td>key</td>
    <td>string</td>
    <td>Name of the data key</td>
  </tr>
  </table>

- ### refreshAllPlayerData(toEveryone)

  Effectively syncs the shared data

  <table>
  <tr>
    <th>Params</th>
    <th>type</th>
    <th>Details</th>
  </tr>
  <tr>
    <td>toEveryone</td>
    <td>boolean</td>
    <td>If set to true, the data will be synced to all players, otherwise only to the client who requested it</td>
  </tr>
  </table>

- ### setRadioVolume(volume)

  Changes the volume of voices over radio

  <table>
  <tr>
    <th>Params</th>
    <th>type</th>
    <th>Details</th>
  </tr>
  <tr>
    <td>volume</td>
    <td>number</td>
    <td>Changes the radio volume</td>
  </tr>
  </table>


Note: Exports will always remain the same, although this README.md will be changed and updated often as we further develop TokoVoIP
