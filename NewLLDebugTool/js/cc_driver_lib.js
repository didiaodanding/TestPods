window.cc_driver_lib = {
    /**
     * 获取当前根场景
     */
    getRootScene: function(){
        let scene = null;
        if (cc.director.getScene) {
            scene = cc.director.getScene();
        } else {
            scene = cc.director.getRunningScene();
        }
        return scene;
    },

    /**
     * 根据xpath查找并返回目标节点，先调用系统默认方法查找，对于查找不到的再具体处理
     * @param {String} xpath 从根节点定位至目标节点的xpath 
     */
    find: function(xpath){
        
        let _node = cc.find(xpath);
        if (_node) {
            return _node;
        }

        let root_scene = this.getRootScene();
        let xpath_arr = xpath.split('/');
        xpath_arr.unshift(root_scene);
        //TODO 当没有找到对应节点时，返回哪一步过滤错误
        try {
            return xpath_arr.reduce((node, child) => {
                if (!child.endsWith(']')){
                    return node.getChildByName(child);
                } else {
                    let match_res = child.match(/(.*)\[(\d+)\]/);
                    return node._children[match_res[2]];
                }
            })    
        } catch (error) {
            console.log(`[pretty] 没有找到对应‘${xpath}’的节点`);
            return null;
        }
    },
    
    
    /**
     * 节点点击，如果节点有Button组件直接触发绑定的点击事件，否则使用坐标点击
     * @param {String} xpath 从根节点定位至目标节点的xpath
     */
    clickByXpath: function(xpath){
        let _node = this.find(xpath);
        if (!_node) return false; 
        try{
            return this.clickByNode(_node);
        } catch (error) {
            return false ;
        }
    },

    /**
     * 节点点击
     * @param {cc.Node} _ndoe 需要点击的节点
     */
    clickByNode: function(_node) {
        if (_node.getComponent(cc.Button)) {
            // 节点有Button组件，直接触发绑定的点击事件
            if (_node.getComponent(cc.Button).clickEvents[0]){
                _node.getComponent(cc.Button).clickEvents[0].emit(['click']);
            } else {
                _node.getComponent(cc.Button).node.emit('click');
                _node.getComponent(cc.Button).node.emit('touchstart');
            }
        } else {
            // 节点没有Button组件，使用坐标点击
            return false;
        }
        return true;
    },

    /**
     * 文本输入，xpath定位的节点必须包含EditBox组件
     * @param {String} xpath 从根节点定位至目标节点的xpath
     * @param {String} _text 输入文本
     */
    inputByXpath: function(xpath, _text){
        let _node = this.find(xpath);
        if (!_node) return false;
        return this.inputByNode(_node, _text);
    },

    /**
     * 对目标节点输入文本
     * @param {cc.Node} _node 输入文本的目标节点
     * @param {String} _text 输入文本
     */
    inputByNode: function(_node, _text){ 
        if (_node.getComponent(cc.EditBox)){
            _node.getComponent(cc.EditBox).string = _text;
            return true;
        } else {
            if (!_node.children.length) {
                throw new Error('Node contains no cc.EditBox component!');
                return false;
            }
            child_node = _node.children[0]; //默认搜索第一个子节点
            return this.inputByNode(child_node, _text);
        }
    },

    /**
     * 获取目标节点上的文本，xpath定位的节点必须包含Label组件
     * @param {String} xpath 从根节点定位至目标节点的xpath
     */
    getTextByXpath: function(xpath){
        let _node = this.find(xpath);
        if (!_node) return null;
        return this.getTextByNode(_node);
    },

    /**
     * 获取目标节点上的文本
     * @param {cc.Node} _node 获取文本的目标节点
     */
    getTextByNode: function(_node){
        if (_node.getComponent(cc.Label)) {
            return _node.getComponent(cc.Label).string;
        } else {
            if (!_node.children.length) {
                throw new Error('Node contains no cc.Label component!');
                return null;
            }
            child_node = _node.children[0]; //默认只搜索第一个子节点
            return this.getTextByNode(child_node);
        }
    },

    /**
     * 计算xpath定位节点的屏幕GL坐标
     * @param {String} _xpath 从根节点定位至目标节点的xpath
     */
    getTouchPointByXpath: function(_xpath){
        let _node = this.find(_xpath);
        if (_node) {
            return this.getTouchPointByNode(_node);
        } else {
            return null;
        }
    }, 

    /**
     * 计算节点的屏幕GL坐标
     * @param {cc.Node} _node 获取点击坐标的节点
     */
    getTouchPointByNode: function(_node){
        let t_matrix = _node.getNodeToWorldTransformAR();
        if (cc.Camera.main && cc.Camera.main.containsNode(_node)) {
            t_matrix = cc.affineTransformConcatIn(t_matrix, cc.Camera.main.viewMatrix);
        }
        var Vec2 = cc.Vec2 || cc.math.Vec2 || cc.math.Vec3;
        let _point = cc.pointApplyAffineTransform(new Vec2(0, 0), t_matrix);
        
        let _rst_point = {
            x: 0,
            y: 0
        };
        //将GL坐标转化为屏幕坐标
        //cocos界面一般都是横屏
        //TODO 适配竖屏和刘海屏
        let _win_size = cc.winSize;
        _rst_point.x = _point.x/_win_size.width;
        _rst_point.y = _point.y/_win_size.height ;
        _rst_point.y = 1 - _rst_point.y ;
        return JSON.stringify(_rst_point);
    },

    /**
     * 获取当前场景名称
     */
    getCurrSceneName: function(){
        let _curr_scene = this.getRootScene();
        if (_curr_scene) {
            return _curr_scene.getName();
        } else {
            return null;
        }
    },

    /**
     * 判断节点是否可见
     * @param {String} cpath 定位节点的cpath
     */
    isNodeVisible: function(cpath){
        let _node = this.find(cpath);
        if (_node){
            return _node._activeInHierarchy;
        } else {
            return false;
        }
    },

    /**
     * 返回子节点的名称列表
     * @param {String} cpath 定位节点的cpath
     */
    getChildren: function(cpath){
        let _node = this.find(cpath);
        if(!_node){
            return null ;
        }
        let child_name_list =  _node.children.map(child => child.name);
        return JSON.stringify(child_name_list);
    },
    
    /**
     * 根据xpath查找绑定事件的名字
     * @param {String} xpath 从根节点定位至目标节点的xpath
     */
    getClickEventNameByXpath: function(xpath) {
       let _node = this.find(xpath);
        if (!_node) return ""; 

        return this.getClickEventNameByNode(_node);
        
    },

    
     /**
     * 根据_node查找绑定事件的名字
     * @param {cc.Node} _ndoe 需要查找绑定事件的节点
     */
    getClickEventNameByNode: function(_node) {
        if (_node.getComponent(cc.Button)) {
            // 节点有Button组件，直接返回绑定的点击事件的名字
            if (_node.getComponent(cc.Button).clickEvents[0]){
                return _node.getComponent(cc.Button).clickEvents[0].handler;
            } 
        }
        // 节点没有Button组件，返回空
        return "";
        
    },
    
    /**
     * 按{Width:,Top:,Left:,Height:}的格式获取节点的位置框
     * @param {cc.Node} _node 获取位置框的目标节点
     */
    getNodeRect: function(_node){
        let bounding_box = _node.getBoundingBoxToWorld();
        let up_left = {
            x: bounding_box.x,
            y: bounding_box.y
        };

        if (cc.Camera.main && cc.Camera.main.containsNode(_node)){
            up_left = cc.pointApplyAffineTransform(up_left, cc.Camera.main.viewMatrix)
        };

        let _rect = {
            Width: Math.floor(bounding_box.width),
            Top: Math.floor(cc.winSize.height - bounding_box.height - up_left.y),
            Left: Math.floor(up_left.x),
            Height: Math.floor(bounding_box.height)
        };

        return _rect;
    },

    /**
     * 输出用于uispy的节点层级树
     */
    dumpUITree: function(){
        let _scene = this.getRootScene();
        let root_node_info = {
            Type: 'cc.Node',
            Enabled: 'True',
            Children: _scene.children.map(child => this.dumpNodeTree(child)),
            Visible: 'True',
            IntId: -1,
            Hashcode: 0,
            Id: _scene.name,
            Rect: {
                Width: Math.floor(cc.winSize.width),
                Top: 0,
                Left: 0,
                Height: Math.floor(cc.winSize.height)
            },
            Desc: ''
        };

        return JSON.stringify(root_node_info);
    },

    /**
     * 解析节点层级
     * @param {cc.Node} _node 解析的节点
     */
    dumpNodeTree: function(_node){
        let node_info = {
            Type: 'cc.Node',
            Enabled: 'True',
            Children: _node.children.map(child => this.dumpNodeTree(child)),
            Visible: 'True',
            IntId: -1,
            Hashcode: 0,
            Id: _node.name,
            Rect: this.getNodeRect(_node),
            Desc: ''
        };

        return node_info;
    }
}
