module.exports = {
  "root": true,
  "parserOptions": {
    "ecmaVersion": 2020,
    "sourceType": "module",
  },
  "env": {
    "es6": true,
    "node": true,
  },
  "extends": [
    "eslint:recommended",
    "google",
  ],
  "rules": {
    "quotes": "off",
    "indent": "off",
    "max-len": "off",
    "quote-props": "off",
    "object-curly-spacing": "off",
    "space-before-function-paren": "off",
    "no-trailing-spaces": "off",
    'require-jsdoc': [
      'error',
      {
        require: {
          FunctionDeclaration: false,
          MethodDefinition: false,
          ClassDeclaration: false,
          ArrowFunctionExpression: false,
          FunctionExpression: false,
        },
      },
    ],
  },
};
