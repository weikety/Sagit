//
//  开源：https://github.com/cyq1162/Sagit
//  作者：陈裕强 create on 2017/12/12.
//  博客：(昵称：路过秋天） http://www.cnblogs.com/cyq1162/
//  起源：IT恋、IT连 创业App http://www.itlinks.cn
//  Copyright © 2017-2027年. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (STUIViewEvent)
typedef  void(^AfterEvent)(NSString *eventType, id para);
//可以附加的点击事件 (存档在keyvalue中时，无法传参（内存地址失效），只能针对性存runtime的属性)
typedef  void(^OnViewClick)(id view);
typedef  void(^OnViewDrag)(id view);
typedef  void(^OnLongPress)(id view);
typedef  void(^ViewDescription)(id view);
#pragma mark 扩展系统事件 - 点击
//!点击事件的间隔（单位秒s)
-(NSInteger)clickInterval;
//!设置点击事件的间隔（单位秒s)
-(UIView*)clickInterval:(NSInteger)sencond;
//!执行点击事件
-(UIView*)click;
//!绑定事件 event：指定事件名称，也可以是控制器名称，也可以指向其它UI的事件，如：Age.click (Age是其它UI的name）
-(UIView*)addClick:(NSString*)event;
//!绑定事件 并指定target
-(UIView*)addClick:(NSString *)event target:(UIViewController*)target;
//!绑定事件 用代码块的形式
-(UIView*)onClick:(OnViewClick)block;
//!移除绑定点击事件
-(UIView*)removeClick;

#pragma mark 扩展系统事件 - 长按
//!执行长按事件
-(UIView*)longPress;
//!绑定事件 event：指定事件名称，也可以是控制器名称，也可以指向其它UI的事件，如：Age.click (Age是其它UI的name）
-(UIView*)addLongPress:(NSString*)event;
//!绑定事件 并指定target
-(UIView*)addLongPress:(NSString *)event target:(UIViewController*)target;
//!绑定事件 用代码块的形式
-(UIView*)onLongPress:(OnLongPress)block;
//!移除绑定长按事件
-(UIView*)removeLongPress;

#pragma mark 扩展系统事件 - 拖动
//!执行拖动事件
-(UIView*)drag;
//!绑定事件 event：指定事件名称，也可以是控制器名称，也可以指向其它UI的事件，如：Age.drag (Age是其它UI的name）
-(UIView*)addDrag:(NSString*)event;
//!绑定事件 并指定target
-(UIView*)addDrag:(NSString *)event target:(UIViewController*)target;
//!绑定事件 用代码块的形式
-(UIView*)onDrag:(OnViewDrag)block;
//!移除绑定拖动事件
-(UIView*)removeDrag;

#pragma mark 扩展的回调事件
-(AfterEvent)onAfter;
//!绑定事件 用代码块的形式
-(UIView*)onAfter:(AfterEvent)block;

#pragma mark 增加描述
//!提供一个代码块，方便代码规范 description处可以写代码块的说明文字
-(UIView*)block:(NSString*)description on:(ViewDescription)descBlock;
//!块写法，用于包含添加子视图
-(UIView*)block:(ViewDescription)descBlock;
@end
