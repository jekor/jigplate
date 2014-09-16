# Jigplate - Logicless, Language-Agnostic, Pattern-Matching Templates

## Usage

jigplate *template* [*template* ...]

Jigplate takes data from stdin in the form of JSON values and template files as arguments.

## Examples

### Object

Objects will match the first template that has slots for each of its keys.

#### Data

```JSON
{"name": "hi", "title": "Welcome"}
```

#### Templates

##### article-item.html

```HTML
<li><a href="/article/{name}">{title}</a></li>
``` 

#### Command

```ShellSession
$ echo '{"name": "hi", "title": "Welcome"}' | jigplate template/article-item.html
```

#### Result

```HTML
<li><a href="/article/hi">Welcome</a></li>
```

### Array

Arrays will concatenate their contents.

#### Data

```JSON
[{"name": "hi",    "title": "Welcome"},
 {"name": "intro", "title": "Introduction"}]
```

#### Templates

##### article-item.html

```HTML
<li><a href="/article/{name}">{title}</a></li>
```

#### Command

```ShellSession
$ echo '[{"name": "hi", "title": "Welcome"}, {"name": "intro", "title": "Introduction"}]' | jigplate template/article-item.html
```

#### Result

```HTML
<li><a href="/article/hi">Welcome</a></li>
<li><a href="/article/intro">Introduction</a></li>
```

### Nesting

Nesting is done in the data, not in the templates.

#### Data

```JSON
{"articles": [{"name": "hi",    "title": "Welcome"},
              {"name": "intro", "title": "Introduction"}]}
```

#### Templates

##### article-item.html

```HTML
<li><a href="/article/{name}">{title}</a></li>
```

##### page.html

```HTML
<h2>Articles</h2>
<ul>
  {articles}
</ul>

#### Command

```ShellSession
$ echo '{"articles": [{"name": "hi", "title": "Welcome"}, {"name": "intro", "title": "Introduction"}]}' | jigplate template/article-item.html template/page.html
```

#### Result

```HTML
<h2>Articles</h2>
<ul>
  <li><a href="/article/hi">Welcome</a></li>
  <li><a href="/article/intro">Introduction</a></li>
</ul>
```
