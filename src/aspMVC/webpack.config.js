var path = require("path");
const VueLoaderPlugin = require("vue-loader/lib/plugin");

module.exports = {
    mode: "development",
    entry: {
        site: "./src/js/site.js",
    },
    output: {
        path: path.resolve(__dirname, "wwwroot/js"),
        filename: "[name].js"
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                use: "babel-loader", //使用 babel-loader 來編譯 .js
                exclude: /node_modules/
            },
            {
                test: /\.vue$/,
                use: "vue-loader",
                exclude: /node_modules/
            },
            {
                test: /\.css$/,
                use: ["style-loader", "css-loader"]
            }
        ]
    },
    resolve: {
        extensions: [".js", ".vue"],
        alias: {
            Common: path.resolve(__dirname, "wwwroot/js/common")
        }
    },
    optimization: {
        splitChunks: {
            cacheGroups: {
                common: {
                    test: /[\\/]node_modules[\\/]/,
                    name: "common",
                    chunks: "initial",
                    priority: 2,
                    minChunks: 2
                },
           
            }
        }
    },
    plugins: [
        // make sure to include the plugin!
        new VueLoaderPlugin(),
    ],
    // externals: {
    //     jquery: "jQuery"
    // }
};
