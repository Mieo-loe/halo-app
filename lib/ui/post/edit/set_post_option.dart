import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:halo/app/config.dart';
import 'package:halo/app/provide.dart';
import 'package:halo/module/tag_list.dart';
import 'package:halo/ui/post/edit/edit_post_module.dart';
import 'package:halo/ui/post/edit/select_category.dart';
import 'package:halo/ui/post/edit/select_tag.dart';
import 'package:halo/ui/tag/tag_manager_module.dart';
import 'package:halo/util/Utils.dart';
import 'package:halo/widget/alertdialog.dart';
import 'package:halo/widget/login_text_field.dart';

class SetPostOptionPage extends StatelessWidget {
  final TextEditingController _passwordCtl = new TextEditingController();
  final TextEditingController _slugCtl = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Config.background,
        appBar: AppBar(
          title: Text("文章设置"),
        ),
        body: buildBody(context));
  }

  Widget buildBody(BuildContext context) {
    return Provide<EditPostModule>(builder: (context, child, mode) {
      List<Widget> widgets = List();
      widgets.add(_buildSelectMenu(
          createItem("状态", mode.getStatus(), () {}), _buildSelectItem(status, context), (data) {
        Provide.value<EditPostModule>(context).onStatusChange(data);
      }));
      widgets.add(Divider(height: 1));
      widgets.add(createItem("密码", isEmpty(mode.param.password) ? "未设置" : mode.param.password, () {
        _passwordCtl.text = mode.param.password;
        _buildPassWordDialog(context);
      }));
      widgets.add(Divider(height: 15, color: Colors.transparent));
      widgets.add(
        Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(24, 15, 24, 0),
            child: Text(
              "分类&标签",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Config.lightColor),
            )),
      );
      if (mode.param.categoryIds == null || mode.param.categoryIds.isEmpty) {
        widgets.add(createItem("分类", mode.getSelectCategory(), () {
          pushToNewPage(context, SelectCategoryPage());
        }));
      } else {}

      widgets.add(Divider(height: 1));
      if (mode.param.tagIds == null || mode.param.tagIds.isEmpty) {
        widgets.add(createItem("标签", mode.getSelectTag(), () {
          pushToNewPage(context, SelectTagPage());
        }));
      } else {
        TagList tagList = Provide.value<TagListModule>(context).tagList;
        if (tagList == null) {
          Provide.value<TagListModule>(context).updateList(context);
        }
        Provide<TagListModule>(builder: (context, child, tagModlue) {
          ///对tag进行检测
          return buildChildren(tagModlue.tagList.list.map((tag) {
            if (mode.param.tagIds.contains(tag.id)) {
              return tag;
            }
          }), context);
        });
      }

      widgets.add(Divider(height: 15, color: Colors.transparent));
      widgets.add(
        Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(24, 15, 24, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "推荐图片",
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Config.lightColor),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: FlatButton(
                        color: Config.lightColor,
                        onPressed: () {},
                        child: Text(
                          "选择推荐图片",
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        )))
              ],
            )),
      );

      widgets.add(Divider(height: 15, color: Colors.transparent));
      widgets.add(
        Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(24, 15, 24, 0),
            child: Text("更多选项",
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Config.lightColor))),
      );
      widgets.add(createItem("slug", isEmpty(mode.param.url) ? "未设置" : mode.param.url, () {
        _slugCtl.text = mode.param.url;
        _buildSlugDialog(context);
      }));
      widgets.add(Divider(height: 1));
      widgets.add(_buildSelectMenu(
          createItem("是否允许评论", mode.allowComment(), () {}), _buildSelectItem(comments, context),
          (data) {
        Provide.value<EditPostModule>(context).onCommentChange(data);
      }));
      widgets.add(Divider(height: 1));
      widgets.add(createItem("自定义模板", "未设置", () {}));
      return ListView.builder(
          itemCount: widgets.length,
          itemBuilder: (BuildContext context, int index) {
            return widgets[index];
          });
    });
  }

  /// create Item empty
  Widget createItem(title, subtitle, Function callBack) {
    return InkWell(
      onTap: callBack,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(24, 13, 24, 13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 15, color: Config.fontColor),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Config.fontLightColor),
            ),
          ],
        ),
      ),
    );
  }

  /// create content item
  Widget createContentItem(title, Widget contetn, Function callBack) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24, 13, 24, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 15, color: Config.fontColor),
          ),
          contetn,
        ],
      ),
    );
  }

  TextStyle style = TextStyle(fontSize: 16, color: Color.fromARGB(255, 102, 142, 170));

  _openNew(BuildContext context) {
//    pushToNewPage(context, EditPostPage());
  }

  _buildSelectMenu(hit, itemList, change) {
    return Container(
      color: Colors.white,
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          iconSize: 0,
          items: itemList,
          hint: hit,
          isExpanded: true,
          onChanged: change,
        ),
      ),
    );
  }

  _buildSelectItem(HashMap<dynamic, String> map, BuildContext context) {
    List<DropdownMenuItem> list = List();
    map.forEach((key, value) {
      list.add(DropdownMenuItem(
          value: key,
          child: Container(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: Config.fontColor),
            ),
            width: MediaQuery.of(context).size.width - 24,
          )));
    });
    return list;
  }

  /// 设置密码
  _buildPassWordDialog(BuildContext context) {
    AlertContentDialog(context, "密码", () {
      Provide.value<EditPostModule>(context).onPasswordChange(_passwordCtl.text);
    },
        SizedBox(
          child: Column(
            children: [
              loginTextField("只有知道此密码才能查看这篇文章", _passwordCtl, null, inputType: TextInputType.number)
            ],
          ),
          height: 60,
        ));
  }

  ///设置 slug
  _buildSlugDialog(BuildContext context) {
    AlertContentDialog(context, "slug", () {
      Provide.value<EditPostModule>(context).onUrlChange(_slugCtl.text);
    },
        SizedBox(
          child: Column(
            children: [
              loginTextField("slug是文章标题URL友好型版本", _slugCtl, null, inputType: TextInputType.url)
            ],
          ),
          height: 60,
        ));
  }

  Widget buildChildren(List<Tag> children, BuildContext context) {
    List<Widget> tiles = [];
    Widget content;
    for (var item in children) {
      tiles.add(
        Chip(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: Utils.nameToColor(item.name),
          label: new Text(item.name),
          deleteIcon: Icon(
            Icons.close,
            color: Colors.black,
            size: 20,
          ),
          onDeleted: () {
            Provide.value<TagListModule>(context).delete(item);
          },
        ),
      );
    }
    content = Padding(
      padding: EdgeInsets.all(10),
      child: Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.start, children: tiles),
    );
    return content;
  }
}
