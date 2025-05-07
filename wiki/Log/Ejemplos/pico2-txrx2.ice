{
  "version": "1.2",
  "package": {
    "name": "",
    "version": "",
    "description": "",
    "author": "",
    "image": ""
  },
  "design": {
    "board": "alhambra-ii",
    "graph": {
      "blocks": [
        {
          "id": "da480e3d-5122-45e4-bab1-6d0edfd4ae4b",
          "type": "basic.output",
          "data": {
            "name": "",
            "virtual": false,
            "pins": [
              {
                "index": "0",
                "name": "TX",
                "value": "61"
              }
            ]
          },
          "position": {
            "x": 1160,
            "y": 464
          }
        },
        {
          "id": "ed419b90-1fb8-4cdc-b3c1-c1b84ccaa69a",
          "type": "basic.input",
          "data": {
            "name": "RX",
            "virtual": false,
            "pins": [
              {
                "index": "0",
                "name": "D13",
                "value": "64"
              }
            ],
            "clock": false
          },
          "position": {
            "x": 440,
            "y": 552
          }
        },
        {
          "id": "390087ca-0125-4d8b-a839-600ebbc5e063",
          "type": "basic.info",
          "data": {
            "info": "## Recibir desde la pico2",
            "readonly": true
          },
          "position": {
            "x": 440,
            "y": 432
          },
          "size": {
            "width": 240,
            "height": 40
          }
        },
        {
          "id": "293270ff-76a5-4d93-9a00-06389333594d",
          "type": "basic.info",
          "data": {
            "info": "## Transmitir hacia el PC",
            "readonly": true
          },
          "position": {
            "x": 960,
            "y": 392
          },
          "size": {
            "width": 296,
            "height": 40
          }
        }
      ],
      "wires": [
        {
          "source": {
            "block": "ed419b90-1fb8-4cdc-b3c1-c1b84ccaa69a",
            "port": "out"
          },
          "target": {
            "block": "da480e3d-5122-45e4-bab1-6d0edfd4ae4b",
            "port": "in"
          }
        }
      ]
    }
  },
  "dependencies": {}
}