import Foundation

enum TranslateBDUIConfiguration {
    static let screenJSON = """
    {
      "id": "rootScroll",
      "type": "scrollView",
      "content": {
        "showsVerticalIndicator": true,
        "showsHorizontalIndicator": false
      },
      "constraints": {
        "pinToSuperview": true
      },
      "subviews": [
        {
          "id": "rootStack",
          "type": "stackView",
          "layout": {
            "axis": "vertical",
            "spacing": "m",
            "backgroundColor": "background"
          },
          "constraints": {
            "pinToSuperview": true,
            "top": 24,
            "left": 16,
            "right": 16,
            "bottom": 24
          },
          "subviews": [
            {
              "type": "label",
              "content": {
                "text": "Backend Driven UI Translate",
                "textStyle": "title",
                "numberOfLines": 0,
                "textAlignment": "left"
              }
            },
            {
              "type": "label",
              "content": {
                "text": "The interface is built from a JSON model",
                "textStyle": "caption",
                "numberOfLines": 0
              }
            },
            {
              "type": "separator",
              "content": {
                "color": "separator",
                "thickness": 1
              }
            },
            {
              "id": "inputField",
              "type": "textField",
              "content": {
                "title": "Text",
                "placeholder": "Enter text"
              }
            },
            {
              "type": "stackView",
              "layout": {
                "axis": "horizontal",
                "spacing": "s",
                "distribution": "fillEqually"
              },
              "subviews": [
                {
                  "type": "button",
                  "content": {
                    "title": "Translate",
                    "style": "primary"
                  },
                  "actions": {
                    "tap": {
                      "type": "route",
                      "destination": "translate"
                    }
                  }
                },
                {
                  "type": "button",
                  "content": {
                    "title": "Add to favorites",
                    "style": "secondary"
                  },
                  "actions": {
                    "tap": {
                      "type": "route",
                      "destination": "favorites"
                    }
                  }
                }
              ]
            },
            {
              "id": "resultLabel",
              "type": "label",
              "content": {
                "text": "Translation result will appear here",
                "textStyle": "body",
                "numberOfLines": 0
              }
            },
            {
              "type": "stackView",
              "layout": {
                "axis": "horizontal",
                "spacing": "s",
                "distribution": "fillEqually"
              },
              "subviews": [
                {
                  "type": "button",
                  "content": {
                    "title": "Reload UI",
                    "style": "secondary"
                  },
                  "actions": {
                    "tap": {
                      "type": "reload"
                    }
                  }
                },
                {
                  "type": "button",
                  "content": {
                    "title": "History",
                    "style": "secondary"
                  },
                  "actions": {
                    "tap": {
                      "type": "route",
                      "destination": "history"
                    }
                  }
                },
                {
                  "type": "button",
                  "content": {
                    "title": "Print",
                    "style": "secondary"
                  },
                  "actions": {
                    "tap": {
                      "type": "print",
                      "message": "BDUI print action triggered"
                    }
                  }
                }
              ]
            }
          ]
        }
      ]
    }
    """
}
