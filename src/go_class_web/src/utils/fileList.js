/**
 * 获取文件列表弹窗中的文件数据
 * 如果使用自己上传文件，请注意：
 * 文件id通过文件共享SDK上传后返回，现测试环境与appID无关联。即多个appID上传文件到测试服务器，多个appID的文件在测试服务器共享。
 * 将上传文件成功后返回的 fileID 填到本地数据管理中
 * 其中 isDynamic 仅UI层面显示该文件是否动态 PPT
 * fileList = [
 *  {id:'上传文件通过sdk返回的fileid', name:'文件名', isDynamic:'ui层面显示该文件是否是动态 ppt'}
 * ]
 */

export const fileList = [
    { id:"YOU_FILE_ID_1",name:"YOU_FILE_NAME" },
    { id:"YOU_FILE_ID_2",name:"YOU_FILE_NAME", isDynamic: "true" }
]