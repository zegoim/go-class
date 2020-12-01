package im.zego.goclass.widget;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import im.zego.zegowhiteboard.model.ZegoWhiteboardViewModel;


public class SpinnerAdapter extends ArrayAdapter<ZegoWhiteboardViewModel> {

    private int mResource;
    private LayoutInflater mInflater;

    public SpinnerAdapter(@NonNull Context context, int resource) {
        super(context, resource);
        mInflater = LayoutInflater.from(context);
        mResource = resource;
    }

    @NonNull
    @Override
    public View getView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
        return createViewFromResource(mInflater, position, convertView, parent, mResource);
    }

    @Override
    public View getDropDownView(int position, @Nullable View convertView,
                                @NonNull ViewGroup parent) {
        return createViewFromResource(mInflater, position, convertView, parent, mResource);
    }

    private View createViewFromResource(@NonNull LayoutInflater inflater, int position,
                                        @Nullable View convertView, @NonNull ViewGroup parent, int resource) {
        final View view;
        final TextView text;

        if (convertView == null) {
            view = inflater.inflate(resource, parent, false);
        } else {
            view = convertView;
        }

        text = (TextView) view;

        final ZegoWhiteboardViewModel item = getItem(position);
        text.setText(item.getName());

        return view;
    }

    @Nullable
    @Override
    public ZegoWhiteboardViewModel getItem(int position) {
        if (position < 0)
            return null;
        return super.getItem(position);
    }

    public int getItemPosition(long whiteboardId) {
        int position = -1;
        for (int i = 0; i < getCount(); i++) {
            if (getItem(i).getWhiteboardID() == whiteboardId) {
                position = i;
                break;
            }
        }
        return position;
    }

    public void remove(long whiteboardId) {
        ZegoWhiteboardViewModel data = null;
        for (int i = 0; i < getCount(); i++) {
            if (getItem(i).getWhiteboardID() == whiteboardId) {
                data = getItem(i);
                break;
            }
        }
        if (data != null) {
            remove(data);
        }
    }
}
