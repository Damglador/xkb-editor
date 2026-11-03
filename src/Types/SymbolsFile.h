#include <qdir.h>
#include <qlist.h>
#include <qqmlintegration.h>
#include <qobject.h>
#include <qtmetamacros.h>
#include <qurl.h>

#define s QStringLiteral

class SymbolsFile : public QObject {
    Q_OBJECT
    QML_ELEMENT
private:
    int m_variantIndex = 0;
    QString m_path = {};
public:
    explicit SymbolsFile(QObject* parent = nullptr) : QObject(parent) {}

    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
    void setPath(const QString urlString) {
        QString newPath;
        const QUrl url(urlString);
        if (url.isLocalFile()) {
            newPath = QDir::toNativeSeparators(url.toLocalFile());
        } else {
            newPath = urlString;
        }
        if (m_path == newPath)
            return;
        m_path = newPath;
        Q_EMIT pathChanged();
    }
    QString path() {
        return m_path;
    }

    Q_PROPERTY(int variantIndex READ variantIndex WRITE setVariantIndex NOTIFY variantChanged)
    void setVariantIndex(const int newIndex) {
        if (m_variantIndex == newIndex)
            return;
        m_variantIndex = newIndex;
        Q_EMIT variantChanged();
    }
    int variantIndex() {
        return m_variantIndex;
    }

    Q_INVOKABLE void load(QString filePath) {
        // TODO
    }

    Q_INVOKABLE void clear() {
        setPath(s(""));
        setVariantIndex(0);
        // TODO: clear variants
    }


Q_SIGNALS:
    void error(QString message);

    void fileLoaded();
    void pathChanged();
    void variantChanged();
};



/*
@QmlElement
class SymbolsFile(QObject):
    def __init__(self, parent=None):
        super().__init__(parent)

        self._variantIndex: int = 0
        self._path: str = ""
        self._variants = VariantsList([], parent=self)
        self._variant: Variant | None = None

    fileLoaded = Signal()
    variantChanged = Signal()
    error = Signal(str)

    pathChanged = Signal()
    @Property(str, notify=pathChanged)
    def path(self):
        return self._path

    @path.setter
    def path(self, str):
        self._path = urlparse(str).path
        self.pathChanged.emit()

    @Property(int, notify=variantChanged)
    def variantIndex(self):
        return self._variantIndex

    @variantIndex.setter
    def variantIndex(self, index: int):
        self._variantIndex = int(index)
        self.updateVariant()
        self.variantChanged.emit()

    @Slot()
    def updateVariant(self):
        self._variant = self._variants.get(self._variantIndex)
        self.variantChanged.emit()

    @Property(QObject, notify=variantChanged)
    def variants(self):
        return self._variants

    @Property(Variant, notify=variantChanged)
    def variant(self) -> Variant | None:
        return self._variant

    @Slot(str)
    def load(self, filePath: str):
        try:
            variants = xkb.getVariantsFromFile(urlparse(filePath).path, dropCache=True)
            self._variants.setItems(variants)
            self.variantIndex = 0  # pyright: ignore[reportAttributeAccessIssue]
            self.path = urlparse(filePath).path  # pyright: ignore[reportAttributeAccessIssue]
            self.pathChanged.emit()
            self.fileLoaded.emit()
        except UnicodeDecodeError:
            self.error.emit("Failed to open file. Not a text file.")
        except (UnexpectedCharacters, UnexpectedToken):
            self.error.emit("Failed to parse file. The file is likely not an xkb layout.")

    @Slot(str, result=bool)
    def write(self, filePath: str) -> bool:
        try:
            with open(urlparse(filePath).path, 'w') as file:
                _ = file.write("\n\n".join([variant.toXkb() for variant in self._variants]))
            return True
        except Exception as err:
            self.error.emit(getattr(err, 'message', re.sub(pattern=r'\[Errno \d+\] ', repl='', string=str(err))))
        return False

    @Slot()
    def clear(self):
        self._variants.clear()
        self.variantIndex = 0  # pyright: ignore[reportAttributeAccessIssue]
        self.path = ""  # pyright: ignore[reportAttributeAccessIssue]
*/
